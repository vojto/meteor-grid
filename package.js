Package.describe({
  summary: "Helpers for improving coding in Meteor"
});

Package.on_use(function (api) {
  api.add_files('meteor.coffee', 'client');
  api.add_files('controller.coffee', 'client');
  api.use('coffeescript', ['client','server']);
});