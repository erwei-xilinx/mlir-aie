<!---//===- README.md ---------------------------------------*- Markdown -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Copyright (C) 2024, Advanced Micro Devices, Inc.
// 
//===----------------------------------------------------------------------===//-->

# <ins>Object FIFO Reuse Pattern</ins>

In the previous [section](../../section-2a/README.md#accessing-the-objects-of-an-object-fifo) it was mentioned that the Object FIFO acquire and release functions can be paired together to achieve the behaviour of a sliding window with data reuse. Specifically, this communication pattern occurs when a producer or a consumer of an Object FIFO releases fewer objects than it had previously acquired. As acquiring from an Object FIFO does not destroy the data, unreleased objects can continue to be used without requiring new copies of the data.

It is important to note that each new acquire function will return a new object or array of objects that a process can access, which **includes unreleased objects from previous acquire calls**. The process should always use the result of the **most recent** acquire call to access unreleased objects to ensure a proper lowering through the Object FIFO primitive.

In the example below `of0` is created with a depth of 3 objects: object0, object1, and object2. The process running on the consumer Worker is showcased in the next figure and explained in-depth below.
```python
of0 = ObjectFifo(line_type, name="objfifo0", depth=3) # 3 objects: object0, object1, object2

# External, binary kernel definition
test_fn2 = Kernel(
    "test_func2",
    "test_func2.cc.o",
    [line_type, line_type, np.int32],
)

# Tasks for the cores to perform
def core_fn(of_in, test_func2):
    ### Situation 1
    elems = of_in.acquire(2) # acquires object0 and object1
    test_func2(elems[0], elems[1], line_size)
    of_in.release(1) # releases object0

    ### Situation 2
    elems_2 = of_in.acquire(2) # acquires object2; object1 was previously acquired
    test_func2(elems_2[0], elems_2[1], line_size)
    of_in.release(1) # releases object1

    ### Situation 3
    elems_3 = of_in.acquire(2) # acquires object0; object2 was previously acquired
    test_func2(elems_3[0], elems_3[1], line_size)
    of_in.release(1) # releases object2

    ### Situation 4
    elems_4 = of_in.acquire(2) # acquires object1; object0 was previously acquired

# Create workers to perform the tasks
my_worker = Worker(core_fn, [of0.cons(), test_fn2])
```

The figure below represents the status of the system in each of the marked situations 1 through 4, where the consumer Worker is mapped to Tile B (Tile A is running an implicit producer process that is not part of the code above):    
1. Consumer B first acquires 2 elements from `of0` in the variable `elems`. As this is the first time that B acquires, it will have access to object0 and object1. B then applies `test_func2` on the two acquired elements. Finally, B releases a single object, the oldest acquired one, and keeps object1.
2. B acquires 2 elements in variable `elems_2`. It now has access to object1 (which remains acquired from the first acquire call at step 1), and also to the newly acquired object2. B again applies the function, after which it only releases a single object and keeps object2.
3. B acquires 2 objects in `elems_3` and has access to object2 and object0. B releases a single object and keeps object0.
4. B acquires 2 objects in `elems_4` and has access to object0 and object1 thus returning to the situation at the beginning of step 1.

<img src="./../../../assets/Reuse.png" height="400">

The situations above can be fused into a `for`-loop with 4 iterations. By continuously releasing one less element than it acquired every iteration, the consumer process is implementing the behaviour of a sliding window with 2 objects that slides down by 1 in each iteration:
```python
# Dataflow with ObjectFifos
of0 = ObjectFifo(line_type, name="objfifo0", depth=3) # 3 objects: object0, object1, object2

# External, binary kernel definition
test_fn2 = Kernel(
    "test_func2",
    "test_func2.cc.o",
    [line_type, line_type, np.int32],
)

# Tasks for the cores to perform
def core_fn(of_in, test_func2):
    for _ in range_(4):
        elems = of_in.acquire(2) # acquires object0 and object1
        test_func2(elems[0], elems[1], line_size)
        of_in.release(1) # releases object0

# Create workers to perform the tasks
my_worker = Worker(core_fn, [of0.cons(), test_fn2])
```

-----
[[Up](..)] [[Next](../02_Broadcast/)]
