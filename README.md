Ruby bindings for IdZebra
=========================

[![Build Status](https://secure.travis-ci.org/tjdett/idzebra.png)](https://travis-ci.org/tjdett/idzebra) [![StillMaintained Status](http://stillmaintained.com/tjdett/idzebra.png)](http://stillmaintained.com/tjdett/idzebra)

If you're looking for an open-source Z39.50/SRU server, then you'll probably be
interested in Zebra.

From <http://www.indexdata.com/zebra>:

> Zebra is a high-performance, general-purpose structured text indexing and
> retrieval engine. It reads structured records in a variety of input formats
> (eg. email, XML, MARC) and allows access to them through exact boolean search
> expressions and relevance-ranked free-text queries.

This gem is intended to make adding and deleting individual records from a local
Zebra instance a little bit easier by taking the [Zebra API][api] and wrapping
it in convenience functions.

For example:

```ruby
file_data = File.open('spec/fixtures/oaipmh_test_1.xml') {|f| f.read}
IdZebra::API('spec/config/zebra.cfg') do |repo|
  # Create a new repository with the provided config
  repo.init
  # Add some records
  repo.transaction do
    repo.add_record(file_data)
  end
  repo.commit
  # Delete the records
  repo.transaction do
    repo.delete_record(file_data)
  end
  repo.commit
end
```

Licence
-------

This gem is licenced under the Simplified BSD License. See `COPYING` for
details.

It dynamically links against Zebra, which is licensed under the
[GPL](http://www.indexdata.com/licences/gpl).

Acknowledgements
----------------

This gem was produced as a result of an [ANDS-funded](http://www.ands.org.au/)
project.

[api]: http://www.indexdata.com/zebra/dox/html/api_8h.html
