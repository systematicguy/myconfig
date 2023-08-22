def doublequote(value):
    return '"{}"'.format(value)

class FilterModule(object):
    def filters(self):
        return {
            'doublequote': doublequote,
        }