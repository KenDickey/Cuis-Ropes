Cuis-Ropes
==========

Functional strings for Cuis

This is an experiment to see if we could use functional strings.

The implementation is fairly simple.  No lazy ropes.  No tree rebalance.

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
