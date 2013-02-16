Cuis-Ropes
==========

Functional strings for Cuis

This is an experiment to see if we could use functional strings.

Ropes are a high-level representation of text that offers much better performance than strings for common operations, and generally reduce memory allocations and copies, while only entailing a small degradation of less common operations.

More precisely, where a string is represented as a memory buffer, a rope is a tree structure whose leaves are slices of immutable strings.  Therefore, concatenation, appending, prepending, substrings, etc. are operations that require only trivial tree manipulation, generally without having to copy memory.  In addition, the tree structure of ropes makes them suitable as a form of index to speed-up access to Unicode characters by index in long chunks of text.
The following operations are algorithmically faster in ropes

    extracting a subrope is logarithmic (linear in strings);
    appending/prepending is near-constant time (linear in strings);
    concatenation is near-constant time (linear in strings);
    char length is constant-time (linear in strings);
    access to a character by index is logarithmic (linear in strings);

If a Rope doesNotUnderstand, it prints the message to the transcript and
delegates the message to a its stringRepresentation.

In the text editor, this is #encompassParagraph .

To load the package


    | slash |
    slash := FileDirectory slash.
    CodePackageFile installPackageStream:
        (FileStream concreteStream readOnlyFileNamed: 
            '..', slash, 'Cuis-Ropes', slash, 'Ropes.pck.st'
        )

Then execute

    Rope openTextEditor.
