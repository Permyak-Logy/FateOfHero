class_name ArrayInventory extends Resource

var contents: Array[ItemStack]
const max_size = 50

func insert(item: Item, size: int) -> int:
    if contents.size() == max_size:
        return size 
    contents.append(ItemStack.create(item, size))
    return 0    

func get_item_stacks() -> Array[ItemStack]:
    return contents

func remove(item: Item, size: int):
    var rem: int = size
    for i in range(contents.size() - 1, -1, -1):
        if contents[i].item == item:
            rem -= contents[i].size 
            if rem < 0:
                contents[i].size = -rem
                return 0
            contents.pop_at(i)
            if rem == 0:
                return 0

func remove_is(item_stack: ItemStack):
    return remove(item_stack.item, item_stack.size)

func insert_is(item_stack: ItemStack) -> int:
    return insert(item_stack.item, item_stack.size)