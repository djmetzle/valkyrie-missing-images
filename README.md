# Valkyrie Missing Images Crawler

This provides a utility to curate the missing/deleted images in Valkyrie.

## Report

In order to browse the missing images report, see: [report.md](report/report.md)

## Updating the report

Install selenium with:
```sh
bundle install
```
Note that this generator uses Firefox, so ensure `geckodriver` is on your PATH.

Add the Valkyrie basic auth secret as an ENV variable:
```sh
export VALKYRIE_BASIC_AUTH='Basic XXXXXXX'
```
This is privately accessible here:
https://github.com/iFixit/ifixit/blob/141209ee10198702e7b1eba6c64d3fe551054544/Conf/varnish/production.vcl#L542

Lastly, run the report:
```sh
ruby generate_report.rb
```
and commit the changes to the `report` directory.
