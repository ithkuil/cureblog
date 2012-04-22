(function() {
  var childproc, everyone, fs, util;

  everyone = process.everyone;

  fs = require('fs');

  util = require('util');

  childproc = require('child_process');

  everyone.now.getWidgetData = function(name, callback) {
    var data;
    data = {
      name: name,
      coffee: fs.readFileSync("components/" + name + "/js/" + name + ".coffee", 'utf8'),
      js: fs.readFileSync("components/" + name + "/js/" + name + ".js", 'utf8'),
      html: fs.readFileSync("components/" + name + "/" + name + ".html", 'utf8'),
      css: fs.readFileSync("components/" + name + "/css/" + name + ".css", 'utf8')
    };
    return callback(data);
  };

  everyone.now.saveWidgetData = function(data, callback) {
    var name;
    name = data.name;
    fs.writeFileSync("components/" + name + "/js/" + name + ".coffee", data.coffee, 'utf8');
    childproc.exec("coffee -o components/" + name + "/js -c components/" + name + "/js/" + name + ".coffee", function(er, o, e) {
      console.log(util.inspect(er));
      console.log(o);
      return console.log(e);
    });
    fs.writeFileSync("components/" + name + "/css/" + name + ".css", data.css, 'utf8');
    fs.writeFileSync("components/" + name + "/" + name + ".html", data.html, 'utf8');
    return callback();
  };

}).call(this);
