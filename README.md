# Carp

contains Carp language support for the Glamorous Toolkit. Heavy WIP.

## Contents

The repository contains:
- A SmaCC parser for Carp,
- a highlighter and styler for Carp code inside GT,
- a snippet type for Carp Lepiter snippets,
- a stand-alone code generator for Carp from an intermediate representation,
- a booklet about the process of adding a language to GT, and
- a work-in progress module IDE for Carp based on GT class coders.

## Installing

```
"this will also register the Lepiter booklet"
Metacello new
    baseline: 'Carp';
    repository: 'github://carpentry-org/gt4carp:master/src';
    load
```

## Missing

Still left to do are:
- “finish” the IDE (i.e. bring to a stable, cute state),
- find a way to distribute the server, and
- get you involved!

<hr/>

Have fun!
