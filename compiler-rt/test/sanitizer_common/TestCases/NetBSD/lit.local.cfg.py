def getRoot(config):
    if not config.parent:
        return config
    return getRoot(config.parent)


root = getRoot(config)

if root.target_os not in ["NetBSD"]:
    config.unsupported = True
