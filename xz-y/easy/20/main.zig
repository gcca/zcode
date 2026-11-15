const std = @import("std");

fn isOpening(c: u8) bool {
    return c == '{' or c == '[' or c == '(';
}

fn closingOf(c: u8) u8 {
    return switch (c) {
        '}' => '{',
        ']' => '[',
        ')' => '(',
        else => unreachable,
    };
}

fn validParenthesis(allocator: std.mem.Allocator, s: []const u8) !bool {
    var stack: std.ArrayList(u8) = .empty;
    defer stack.deinit(allocator);

    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        const c = s[i];
        if (isOpening(c)) {
            try stack.append(allocator, c);
            continue;
        }

        const closing = closingOf(c);
        if (stack.items.len == 0 or stack.items[stack.items.len - 1] != closing)
            return false;
        _ = stack.pop();
    }

    return stack.items.len == 0;
}

test "isOpening recognizes only opening brackets" {
    for ("([{") |c| try std.testing.expect(isOpening(c));
    for (")]}a") |c| try std.testing.expect(!isOpening(c));
}

test "closingOf maps closing brackets to their openings" {
    try std.testing.expectEqual(@as(u8, '{'), closingOf('}'));
    try std.testing.expectEqual(@as(u8, '['), closingOf(']'));
    try std.testing.expectEqual(@as(u8, '('), closingOf(')'));
}

test "accepts each bracket type" {
    for ([_][]const u8{ "()", "[]", "{}" }) |s|
        try std.testing.expect(try validParenthesis(std.testing.allocator, s));
}

test "accepts adjacent and nested pairs and empty input" {
    for ([_][]const u8{
        "()[]{}",
        "{[()]}",
        "{[()()]([])}{}[({})]",
        "(()[{}])({[]})",
        "",
    }) |s|
        try std.testing.expect(try validParenthesis(std.testing.allocator, s));
}

test "accepts long inputs" {
    var deeply_nested: [10000]u8 = undefined;
    @memset(deeply_nested[0..5000], '(');
    @memset(deeply_nested[5000..], ')');
    try std.testing.expect(try validParenthesis(std.testing.allocator, &deeply_nested));

    var adjacent: [10000]u8 = undefined;
    for (0..5000) |i| {
        adjacent[2 * i] = '[';
        adjacent[2 * i + 1] = ']';
    }
    try std.testing.expect(try validParenthesis(std.testing.allocator, &adjacent));
}

test "rejects mismatched and incorrectly nested pairs" {
    for ([_][]const u8{ "(]", "[(])" }) |s|
        try std.testing.expect(!try validParenthesis(std.testing.allocator, s));
}

test "rejects unmatched brackets" {
    for ([_][]const u8{
        "(",
        ")",
        "())",
        "(()",
        "{[()()]([])}{}[({})]]",
        "{[()()]([])}{}[({})]({",
    }) |s|
        try std.testing.expect(!try validParenthesis(std.testing.allocator, s));
}

test "rejects deep mismatches and crossed nesting" {
    for ([_][]const u8{ "{[()()]([)]}{}", "{[({[()]})]}[({[}])]" }) |s|
        try std.testing.expect(!try validParenthesis(std.testing.allocator, s));

    var deep: [10000]u8 = undefined;
    @memset(deep[0..4999], '(');
    deep[4999] = '[';
    @memset(deep[5000..], ')');
    try std.testing.expect(!try validParenthesis(std.testing.allocator, &deep));
}
