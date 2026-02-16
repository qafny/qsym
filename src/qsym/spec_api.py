def qspec(spec: str):
    pass

def qassert(spec: str):
    """
    Injects a Qafny assertion.
    Usage: qassert("q[0, n): en ↦ ...")
    """
    pass

def qinvariant(spec: str):
    """
    Injects a loop invariant.
    Usage: qinvariant("q[0, i): nor ↦ ...")
    """
    pass

def qrequires(spec: str):
    """
    Injects a method precondition.
    Usage: qrequires("q[0, n): nor ↦ |0>")
    """
    pass

def qensures(spec: str):
    """
    Injects a method postcondition.
    Usage: qensures("q[0, n): had ↦ |+>")
    """
    pass