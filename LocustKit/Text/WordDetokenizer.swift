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

/// A detokenizer that reconstructs simple English-like spacing around punctuation.
public struct WordDetokenizer: Detokenizing
{
    /// Special tokens that affect generated text reconstruction.
    private let specialTokens:      SpecialTokens
    
    /// Punctuation spacing rules used when joining adjacent tokens.
    private let punctuationSpacing: PunctuationSpacing
    
    /// Creates a word detokenizer.
    ///
    /// - Parameters:
    ///   - specialTokens: Special tokens that should be skipped or stop reconstruction.
    ///   - punctuationSpacing: Rules for suppressing spaces around punctuation.
    public init( specialTokens: SpecialTokens = .locust, punctuationSpacing: PunctuationSpacing = .english )
    {
        self.specialTokens      = specialTokens
        self.punctuationSpacing = punctuationSpacing
    }
    
    /// Reconstructs text from tokens using the configured special-token and punctuation rules.
    ///
    /// - Parameter tokens: The tokens to join.
    /// - Returns: The reconstructed text.
    public func detokenize( _ tokens: [ String ] ) -> String
    {
        // Keep the previous emitted token so punctuation spacing can be decided one token at a time.
        tokens.reduce( into: ( output: "", previousToken: String?.none, isComplete: false ) )
        {
            state, token in
            
            if state.isComplete
            {
                return
            }
            
            if token == self.specialTokens.beginningOfSequence
            {
                return
            }
            
            if token == self.specialTokens.endOfSequence
            {
                state.isComplete = true
                
                return
            }
            
            if state.output.isEmpty == false, self.requiresLeadingSpace( before: token, after: state.previousToken )
            {
                state.output.append( " " )
            }
            
            state.output.append( token )
            
            state.previousToken = token
        }
        .output
    }
    
    /// Returns whether a space is needed before a token.
    ///
    /// - Parameters:
    ///   - token: The token about to be appended.
    ///   - previousToken: The most recent emitted token, if any.
    /// - Returns: `true` when a normal leading space should be inserted.
    private func requiresLeadingSpace( before token: String, after previousToken: String? ) -> Bool
    {
        if self.punctuationSpacing.closingWithoutLeadingSpace.contains( token )
        {
            return false
        }
        
        if let previousToken, self.punctuationSpacing.openingWithoutTrailingSpace.contains( previousToken )
        {
            return false
        }
        
        return true
    }
}
