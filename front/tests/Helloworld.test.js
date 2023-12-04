import { test } from 'vitest';
import { expect, it } from 'vitest'

test('Always Passes', () => {
    const actual = 1;
    const expected = 1;

    // This assertion will always be true, making the test pass
    expect(actual).toBe(expected);
});
