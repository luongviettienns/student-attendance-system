angular.module("eduApp").directive("fallbackSrc", function() {
  return {
    link: function(scope, element, attrs) {
      // Khi ảnh lỗi (404 hoặc load fail)
      element.bind("error", function() {
        // Nếu ảnh hiện tại khác fallback → thay thế
        if (attrs.src !== attrs.fallbackSrc) {
          attrs.$set("src", attrs.fallbackSrc);
        }
      });
    }
  };
});
