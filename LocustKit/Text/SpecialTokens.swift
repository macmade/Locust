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

/// Token strings reserved for model and dataset control flow.
public struct SpecialTokens
{
    /// Token used when source text contains a token outside the vocabulary.
    public let unknown:             String
    
    /// Token inserted before the first content token in a sequence.
    public let beginningOfSequence: String
    
    /// Token inserted after the final content token in a sequence.
    public let endOfSequence:       String
    
    /// Creates a special-token set.
    ///
    /// - Parameters:
    ///   - unknown: Token used for out-of-vocabulary text.
    ///   - beginningOfSequence: Token used to mark sequence starts.
    ///   - endOfSequence: Token used to mark sequence ends.
    public init( unknown: String, beginningOfSequence: String, endOfSequence: String )
    {
        self.unknown             = unknown
        self.beginningOfSequence = beginningOfSequence
        self.endOfSequence       = endOfSequence
    }
    
    /// Default special tokens used by Locust.
    public static let locust = Self(
        unknown:             "<unk>",
        beginningOfSequence: "<bos>",
        endOfSequence:       "<eos>"
    )
}
