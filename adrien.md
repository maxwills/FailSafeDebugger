# Notes / questions from Adrien

## SpCodePresenter

We will have to use a `SpCodeInteractionModel`. The `StDebugger` uses its own interaction model (`StDebuggerContextInteractionModel`) but I just saw that `SpContextInteractionModel` just have the exact same code as the debugger interaction model.
I suggest that we use the `SpCodeInteractionModel`?

## Inspector

If we want to keep only one view for our inspector, I propose that we keep the basic one in which we can see `self`, all temps/args, exception and `thisContext`.
However, it looks like the `StDebugger` uses an `StDebuggerContext` for that. Do we use it or do we use something else?


