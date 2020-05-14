# docker-fork-bomb

Strange things happen, when you execute `docker run -it --rm --memory=128M --kernel-memory=16M lmmdock/fork-bomb`. Be aware that your complete system may crash, even your file system might get corrupted by this command.

It basically just executes a fork bomb in a resource (memory) constrained container.
