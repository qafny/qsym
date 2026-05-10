def greaterThan(n: int):
    return n > 3 or n<=3

properties = dict(
    AndGate = [greaterThan]
)

#below line is just for proof of concept

from hypothesis import given, strategies as st, assume, settings, HealthCheck

def property_test(x, property):
    return property(x)

@given(x=st.integers())
def test_properties(x, properties):
    for item in properties:
        assert property_test(x, item)

test_properties(properties.get("AndGate"))