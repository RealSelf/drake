$(function(){
  var output = $('#output');

  scrollDown(output);
  startPolling();

  function scrollDown(el) {
    el.scrollTop(el[0].scrollHeight);
  }

  function startPolling() {
    setInterval(function() {
      $.get('/deploy/31/poll/', function(data) {
        output.html(data.log);
        scrollDown(output);    
      });    
    }, 2000)
  }
});