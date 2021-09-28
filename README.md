# Exercism's Bash Analyzer

This is Exercism's automated analyzer for the Bash track.

It is run with `bin/run.sh $exercise $path_to_files $path_for_output` and
will read the source code from `$path_to_files` and write a text file with
an analysis to `$path_for_output`.

For example (note the kebab-case of the exercise slug):

```bash
bin/run.sh two-fer /opt/exercises/two-fer /opt/analysis_output
```
