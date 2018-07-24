

<!-- jQuery 3 -->
<script src="bower_components/jquery/dist/jquery.min.js"></script>
<!-- Bootstrap 3.3.7 -->
<script src="bower_components/bootstrap/dist/js/bootstrap.min.js"></script>
<!-- PACE -->
<script src="bower_components/PACE/pace.min.js"></script>
<!-- Bootstrap WYSIHTML5 -->
<script src="plugins/bootstrap-wysihtml5/bootstrap3-wysihtml5.all.min.js"></script>
<!-- CodeSeven toastr notifications -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>

<!-- page script -->
<script type="text/javascript">
  // To make Pace works on Ajax calls
  $(document).ajaxStart(function () {
    Pace.restart()
  })
  $('.ajax').click(function () {
    $.ajax({
      url: '#', success: function (result) {
        $('.ajax-content').html('<hr>Ajax Request Completed !')
      }
    })
  })
</script>
<script>
  $(function () {
    //bootstrap WYSIHTML5 - text editor
    $('.textarea').wysihtml5()
  })
</script>
<script>
toastr.options = {
  "closeButton": true,
  "debug": false,
  "newestOnTop": true,
  "progressBar": true,
  "positionClass": "toast-bottom-left",
  "preventDuplicates": false,
  "onclick": null,
  "showDuration": "300",
  "hideDuration": "1000",
  "timeOut": "5000",
  "extendedTimeOut": "1000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "slideDown",
  "hideMethod": "fadeOut"
}
    <% SELECT CASE Request("MSG")
        CASE "edit" %>
            toastr.success('Item was successfully updated.', '<h3>Success!</h3>')
       <% CASE "add" %>
            toastr.success('Item was successfully added.', '<h3>Success!</h3>')
       <% CASE "delete" %>
            toastr.success('Item was successfully deleted.', '<h3>Success!</h3>')
       <% CASE "autoinit" %>
            toastr.success('Items have been initialized.', '<h3>Success!</h3>')
       <% CASE "sorted" %>
            toastr.success('Sorting has been updated.', '<h3>Success!</h3>')
       <% CASE "notfound" %>
            toastr.error('Provided item ID was not found.', '<h3>Error!</h3>')
    <% END SELECT %>
</script>
