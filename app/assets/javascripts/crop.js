$(function() {
  if ($('#cropbox').length > 0) {
    $('#cropbox').Jcrop({
      onChange: update_crop,
      onSelect: update_crop,
      setSelect: [0, 0, 500, 500],
      aspectRatio: 1
    });
  }
});