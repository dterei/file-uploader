var express = require('express');
var logger = require('morgan');
var path = require('path');
var fs = require('fs');
var crypto = require('crypto')
var winston = require('winston');

var title = 'CS240h Lab Uploader';

var app = express();
app.configure(function () {
  app.use(express.bodyParser());
});

// View Engine Setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// Middleware Setup
app.use(logger('dev'));
app.use(require('less-middleware')({ src: path.join(__dirname, 'public') }));
app.use(express.static(path.join(__dirname, 'public')));
app.use(app.router);

// Setup log file for file uploads
winston.add(winston.transports.File, { filename: 'file-uploads.log' });

// Routes

app.get('/', function(req, res){
  res.render('index', { title: title });
});

app.post('/upload', function(req, res){
  var suid  = req.param('suid');
  var bonus = req.param('bonus');
  var msg   = req.param('msg');
  var file  = req.files.submission;
  console.log("Starting upload for" + suid);

  bonus = !bonus ? 'false' : 'true';

  fs.readFile(file.path, function (err, data) {
    if (!file.name || err) {
      console.log("Error with file upload: " + err);
      var emsg = "null error";
      if (err) {
        emsg = err.message;
      }
      res.render('error', {
        message: emsg,
        error: err
      });
      return;
    }

    // compute filename
    var shasum = crypto.createHash('sha1').update(data);
    var digest = shasum.digest('hex');
    var newPath = path.join(__dirname, "uploads", digest);

    // log write
    var time = new Date();
    winston.info(msg, {
      uploaded: time.getTime(),
      suid: suid,
      digest: digest,
      bonus: bonus,
      file: file.name
    });

    // save upload
    fs.writeFile(newPath, data, function (err) {
      if (err) {
        console.log("Error saving uploaded file: " + err);
        res.render('error', {
          message: err.message,
          error: err
        });
      } else {
        res.render('success', {
          title: title,
          digest: digest,
          time: time.toString()
        });
      }
    });

  });
});

/// Error Handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.render('error', {
            message: err.message,
            error: err
        });
    });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.render('error', {
        message: err.message,
        error: {}
    });
});

module.exports = app;
