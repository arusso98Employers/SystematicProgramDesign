Exercise 1 Make an example representing the content in the HTML document snippet above.

Exercise 2 Design a function content-to-HTML that converts content to a string representation of the HTML markup. For example, convert the example from exercise 1 should produce a string that starts "<h1>Mark it</h1><p>Edit the file named <b>EXACTLY</b> <tt>ml.rkt</tt> for...".

(There are some subtle issues like what to do if there is an item in the document which is a string that looks like HTML, e.g. "<tt>", but we will ignore those issues for now.)

Exercise 3 Design a function content-contains-tag? that determines if an element with a given tag occurs within any part of the content of document.

Exercise 4 Design a function content-length that sums up the length of all the textual items with a document.

Exercise 5 Design a function content-contains-elem? that consumes a predicate on elements and returns true if the content contains any element that satisfies the predicate.

Exercise 6 Design a function content-retag that takes two tags and renames every occurrence of the first tag to the second tag within the given content.

Exercise 7 Design a function content-max-nesting that determines the maximum level of element nesting within the given content. (The max nesting level in the example above is 2.)

Exercise 8 Design a function content-text that produces a list of all the text that occurs in a document, in the order it occurs.

Exercise 9 Design a function content-skeleton that, given content, produces a document that is like the given content, but with all text removed.