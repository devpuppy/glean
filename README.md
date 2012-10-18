**glean** *verb*

1. Extract (information) from various sources.
2. Collect gradually and bit by bit.

## Glean is a gem for split testing
It runs atop [Trebuchet](https://github.com/airbnb/trebuchet) or a similar feature launcher. It makes configuring experiments consistent and reliable.

#### first you ...

```ruby
options = {
  :bucket_names => ['Aces', 'B-Team', 'Control'],
  :bucket_percent => 1, # or 5, 10, 20, 50
  :subject => 'user', # or 'visitor'
  :name => "Awesome Sauce"
}

ex = Glean::Experiment.new(options)
ex.save # write to backend (Redis)
ex.configure # set up Trebuchet features
```

#### and then you could ...

```xml+erb
<% treatment = Glean['Awesome Sauce'].downcase %>
<input type="button" class="button-color-<%= treatment %>" />
```


```ruby
case Glean["Awesome Sauce"]
  do_this when "Aces"
  do_that when "B-Team"
  do_the_other when "Control"
  oh_you_are_not_part_of_this_experiment_at_all_are_you? when nil
end

```

#### and then you can also ...

```ruby
ex = Glean::Experiment.find("Awesome Sauce")
ex.valid?
ex.errors
```