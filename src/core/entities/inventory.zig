pub const ItemKind = enum {
    health,
    shield,
    rapid_fire,
};

pub const Item = struct {
    kind: ItemKind,
    count: u8 = 1,
};

pub const slot_count = 8;

const Self = @This();
slots: [slot_count]?Item = @splat(null),

pub fn add(
    self: *Self,
    item: Item,
) bool {
    for (&self.slots) |*slot| {
        if (slot.*) |*existing| {
            if (existing.kind == item.kind) {
                existing.count += item.count;
                return true;
            }
        }
    }

    for (&self.slots) |*slot| {
        if (slot.* == null) {
            slot.* = item;
            return true;
        }
    }

    return false;
}

pub fn consume(
    self: *Self,
    index: usize,
) ?ItemKind {
    if (index >= self.slots.len) {
        return null;
    }

    const item = self.slots[index] orelse
        return null;

    if (item.count <= 1) {
        self.slots[index] = null;
    }
    else {
        self.slots[index].?.count -= 1;
    }

     return item.kind;
}

