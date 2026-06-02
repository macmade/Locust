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

public struct WordDetokenizer: Detokenizing
{
    private let specialTokens:      SpecialTokens
    private let punctuationSpacing: PunctuationSpacing
    
    public init( specialTokens: SpecialTokens = .locust, punctuationSpacing: PunctuationSpacing = .english )
    {
        self.specialTokens      = specialTokens
        self.punctuationSpacing = punctuationSpacing
    }
    
    public func detokenize( _ tokens: [ String ] ) -> String
    {
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
