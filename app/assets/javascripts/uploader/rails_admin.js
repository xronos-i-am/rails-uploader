//= require uploader/tmpl
//= require uploader/canvas-to-blob
//= require uploader/load-image
//= require uploader/jquery.fileupload
//= require uploader/jquery.fileupload-process
//= require uploader/jquery.fileupload-resize
//= require uploader/jquery.fileupload-validate
//= require uploader/jquery.fileupload-ui

$(document).off('init.sort').on('init.sort', '.uploader-files', function() {
    var $t = $(this);
    $t.sortable({
        update: function(event, ui) {
            var sort = [];
            $t.children().each(function() {
                sort.push($(this).data('id'));
            });
            $.ajax({
                type: 'POST',
                url: $t.data('sortPath'),
                data: {sort: sort.join('|')}
            })
        }
    })
});

$('.uploader-dnd-area input[type=file]').trigger("init.uploader");