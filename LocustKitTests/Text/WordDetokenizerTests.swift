/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Testing
import LocustKit

/// Tests for the word detokenizer.
struct WordDetokenizerTests
{
    /// Verifies that common punctuation is reconstructed without awkward spacing.
    @Test
    func detokenizesCommonPunctuation() async throws
    {
        let detokenizer = WordDetokenizer()
        
        #expect( detokenizer.detokenize( [ "Hello", ",", "world", "!" ] )      == "Hello, world!" )
        #expect( detokenizer.detokenize( [ "Look", "(", "inside", ")", "." ] ) == "Look (inside)." )
    }
    
    /// Verifies that beginning and end sequence tokens affect reconstruction.
    @Test
    func handlesSpecialTokens() async throws
    {
        let detokenizer = WordDetokenizer()
        
        #expect( detokenizer.detokenize( [ SpecialTokens.locust.beginningOfSequence, "Hello", SpecialTokens.locust.endOfSequence, "after-eos" ] ) == "Hello" )
    }
    
    /// Verifies that callers can provide a custom special-token set.
    @Test
    func supportsInjectedSpecialTokens() async throws
    {
        let specialTokens = SpecialTokens(
            unknown:             "[unknown]",
            beginningOfSequence: "[start]",
            endOfSequence:       "[end]"
        )
        let detokenizer = WordDetokenizer( specialTokens: specialTokens )
        
        #expect( detokenizer.detokenize( [ "[start]", "Hello", "[end]", "ignored" ] ) == "Hello" )
    }
    
    /// Verifies that callers can provide custom punctuation spacing rules.
    @Test
    func supportsInjectedPunctuationSpacing() async throws
    {
        let detokenizer = WordDetokenizer( punctuationSpacing: PunctuationSpacing( closingWithoutLeadingSpace: [ "~" ], openingWithoutTrailingSpace: [ "^" ] ) )
        
        #expect( detokenizer.detokenize( [ "Hello", "~", "^", "world" ] ) == "Hello~ ^world" )
    }
    
    /// Verifies that empty token input produces empty text.
    @Test
    func handlesEmptyInput() async throws
    {
        let detokenizer = WordDetokenizer()
        
        #expect( detokenizer.detokenize( [] ).isEmpty )
    }
}
