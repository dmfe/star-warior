const Self = @This();
current_score: u64 = 0,
max_score: u64 = 0,

pub fn addScore(self: *Self, amount: u64) void {
    self.current_score += amount;
    self.max_score = @max(self.max_score, self.current_score);
}

pub fn resetCurrent(self: *Self) void {
    self.current_score = 0;
}

