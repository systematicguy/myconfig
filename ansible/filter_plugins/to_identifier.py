def to_identifier(value):
    import re

    # Replace special characters with underscores
    identifier = re.sub(r'[^a-zA-Z0-9]', '_', value)

    return identifier

class FilterModule(object):
    def filters(self):
        return {
            'to_identifier': to_identifier,
        }