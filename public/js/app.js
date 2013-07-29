$(function(){
  var output = $('#output');

  scrollDown(output);
  startPolling();

  function scrollDown(el) {
    el.scrollTop(el[0].scrollHeight);
  }

  function startPolling() {
    setInterval(function() {
      $.get('/deploy/' + id() + '/poll/', function(data) {
        output.html(data.log);
        scrollDown(output);    
      });    
    }, 2000)
  }

  function id() {
    path = window.location.pathname.split('/');
    return path[2];
  }
});