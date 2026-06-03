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

/// Rules that control where spaces are suppressed around punctuation tokens.
public struct PunctuationSpacing
{
    /// Tokens that should not receive a leading space.
    public let closingWithoutLeadingSpace:  Set< String >
    
    /// Tokens after which the next token should not receive a leading space.
    public let openingWithoutTrailingSpace: Set< String >
    
    /// Creates punctuation spacing rules.
    ///
    /// - Parameters:
    ///   - closingWithoutLeadingSpace: Tokens that attach to the previous token.
    ///   - openingWithoutTrailingSpace: Tokens that attach to the following token.
    public init( closingWithoutLeadingSpace: Set< String >, openingWithoutTrailingSpace: Set< String > )
    {
        self.closingWithoutLeadingSpace  = closingWithoutLeadingSpace
        self.openingWithoutTrailingSpace = openingWithoutTrailingSpace
    }
    
    /// Default spacing rules for common English punctuation.
    public static let english = Self(
        closingWithoutLeadingSpace:  [ ".", ",", "!", "?", ":", ";", ")", "]", "}" ],
        openingWithoutTrailingSpace: [ "(", "[", "{" ]
    )
}
