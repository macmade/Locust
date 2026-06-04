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

/// Tests for the word tokenizer.
struct WordTokenizerTests
{
    /// Verifies that words and punctuation become separate tokens.
    @Test
    func splitsWordsAndPunctuation() async throws
    {
        let tokenizer = WordTokenizer()
        
        #expect( tokenizer.tokenize( "Hello, world!" ) == [ "Hello", ",", "world", "!" ] )
    }
    
    /// Verifies that tokenization does not alter letter casing.
    @Test
    func preservesCasing() async throws
    {
        let tokenizer = WordTokenizer()
        
        #expect( tokenizer.tokenize( "Hello HELLO hello" ) == [ "Hello", "HELLO", "hello" ] )
    }
    
    /// Verifies that whitespace separates tokens without being emitted.
    @Test
    func ignoresWhitespaceAndNewlines() async throws
    {
        let tokenizer = WordTokenizer()
        
        #expect( tokenizer.tokenize( "One\t two\n\nthree" ) == [ "One", "two", "three" ] )
    }
    
    /// Verifies that apostrophes remain separate punctuation tokens.
    @Test
    func splitsContractionsAtApostrophes() async throws
    {
        let tokenizer = WordTokenizer()
        
        #expect( tokenizer.tokenize( "Don't stop." ) == [ "Don", "'", "t", "stop", "." ] )
    }
    
    /// Verifies that hyphenated text keeps hyphens as punctuation tokens.
    @Test
    func splitsHyphenatedWordsAtHyphens() async throws
    {
        let tokenizer = WordTokenizer()
        
        #expect( tokenizer.tokenize( "well-known state-of-the-art" ) == [ "well", "-", "known", "state", "-", "of", "-", "the", "-", "art" ] )
    }
    
    /// Verifies that decimal points and currency symbols are emitted separately.
    @Test
    func splitsDecimalsAndSymbols() async throws
    {
        let tokenizer = WordTokenizer()
        
        #expect( tokenizer.tokenize( "3.14 costs $5.00" ) == [ "3", ".", "14", "costs", "$", "5", ".", "00" ] )
    }
    
    /// Verifies that precomposed accented letters remain part of word tokens.
    @Test
    func keepsPrecomposedAccentedLettersInWords() async throws
    {
        let tokenizer = WordTokenizer()
        
        #expect( tokenizer.tokenize( "Caf\u{00E9} na\u{00EF}ve" ) == [ "Caf\u{00E9}", "na\u{00EF}ve" ] )
    }
    
    /// Verifies that decomposed accents remain attached to their base letters.
    @Test
    func keepsCombiningMarksWithBaseLetters() async throws
    {
        let tokenizer = WordTokenizer()
        
        #expect( tokenizer.tokenize( "Cafe\u{0301} deja\u{0300}" ) == [ "Cafe\u{0301}", "deja\u{0300}" ] )
    }
    
    /// Verifies that empty and whitespace-only input produce no tokens.
    @Test
    func handlesEmptyInput() async throws
    {
        let tokenizer = WordTokenizer()
        
        #expect( tokenizer.tokenize( "" ).isEmpty )
        #expect( tokenizer.tokenize( " \n\t " ).isEmpty )
    }
}
