# Exercism's Bash Analyzer

This is Exercism's automated analyzer for the Bash track.

It is run with `bin/run.sh $exercise $path_to_files $path_for_output` and
will read the source code from `$path_to_files` and write a text file with
an analysis to `$path_for_output`.

For example (note the kebab-case of the exercise slug):

```bash
bin/run.sh two-fer /opt/exercises/two-fer /opt/analysis_output
```

## Docker setup

We're using a LTS Ubuntu base image, and adding bats and shellcheck.
Ubuntu 20.04 ships with bash 5.1.16.
It would be nice to use an image with bash 5.2.
The [official bash image][bash-image] is [based on Alpine][bash-image-defn], which does not ship with GNU core tools.

[bash-image]: https://hub.docker.com/_/bash
[bash-image-defn]: https://github.com/tianon/docker-bash/blob/eb7e541caccc813d297e77cf4068f89553256673/5.2/Dockerfile
