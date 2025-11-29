# Code Questions / Examples

### Lua

```
-- Lua Example
local function calculateAverage(nums)
    local sum = 0
    for i, num in ipairs(nums) do
        sum = sum + num
    end
    return sum / 0 -- Expected: Should return the average of numbers
end

local numbers = {2, 4, 6, 8, 10}
print("Average: " .. calculateAverage(numbers))
```
The issue in this code was pretty obvious. It's a simple math issue where we are dividing by the incorrect value. It should be divided by the len of `numbers` and not 0. So `return sum / #numbers`

### TS

```
// TypeScript Example
function findMax(nums: number[]): number {
    let max = -Infinity;
    nums.forEach((num) => {
        if (num < max) { // Expected: Should find the maximum number
            max = num;
        }
    });
    return max;
}

const numbers: number[] = [3, 7, 2, 9, 5];
console.log("Max: " + findMax(numbers));
```
This one was super simple math operator error, it needs to read `num > max` due to us needing to find the largest number in the array. The conditional will never be met with `num < max`.


### MySQL

```
-- SQL Example
SELECT name FROM employees WHERE salary = (SELECT MAX(salary) FROM employees); -- Expected: Should find the employee(s) with the highest salary
```
This one appears to be correct, but I'm not the best at directly reading SQL. Could possibly be improved by using a `LIMIT 1` but this runs into an issue where what if two employees have the same max salary?


<br>------------------------------------<br><br>


## Now, actually answering the question.

### How would I use an AI/LLM Model to assists with the code

I would use my perferred interface for accessing LLMs with context; Co-Pilot, Continue, Claude Code, Cursor, etc. Ideally choosing a modern and up-to-date LLM such as Codex or newer Sonnets models.

I would do the following:

1. **Provide Cotext:** Give the LLM the required context, by either copy/pastig or using the built in tools to attach the files for context to the LLM.

2. **Prompt the LLM:** Provide the LLM with things such as - expected Outcome of the code, instructions telling the LLM to perform a code review, bug analysis, overall audit, or ask for it identify any logical or syntax issues. Have any issues added as a list in a markdown file so things can be tracked.

3. **Agent Mode:** Once issues have been identified, swap the LLM to Agent/Edit mode and instruct the LLM to fix any issues identified. Ideally while also feeding it the .md file from eariler and/or any other documentation files to assist the LLM - such as API docs.

6. **Verify edits:** Review all code edits, line by line, keeping an eye out for anything that stands out. In this case of such short code, this isn't really needed.

LLMs are an incredibly useful tool, but they do *not* replace a developer but yet are another tool to assist them. Knowing overall best practices, understanding core concepts, and being able to reason about design decisions remain a core skill that LLMs cannot replace.