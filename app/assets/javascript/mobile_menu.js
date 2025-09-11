<script>
  document.addEventListener('DOMContentLoaded', function() {
    const mobileMenuButton = document.getElementById('mobile-menu-button');
    const mobileMenu = document.getElementById('mobile-menu');
    const menuIcon = document.getElementById('menu-icon');
    const closeIcon = document.getElementById('close-icon');

    if (mobileMenuButton && mobileMenu && menuIcon && closeIcon) {
      
      mobileMenuButton.addEventListener('click', function() {
        const isExpanded = mobileMenuButton.getAttribute('aria-expanded') === 'true';
        
        mobileMenu.classList.toggle('hidden');
        menuIcon.classList.toggle('hidden');
        closeIcon.classList.toggle('hidden');
        menuIcon.classList.toggle('block');
        closeIcon.classList.toggle('block');
        mobileMenuButton.setAttribute('aria-expanded', !isExpanded);
      });

      const mobileLinks = mobileMenu.querySelectorAll('a');
      mobileLinks.forEach(function(link) {
        link.addEventListener('click', function() {
          closeMobileMenu();
        });
      });

      document.addEventListener('click', function(event) {
        const isClickInsideNav = event.target.closest('nav');
        if (!isClickInsideNav && !mobileMenu.classList.contains('hidden')) {
          closeMobileMenu();
        }
      });

      window.addEventListener('resize', function() {
        if (window.innerWidth >= 640) {
          closeMobileMenu();
        }
      });

      function closeMobileMenu() {
        mobileMenu.classList.add('hidden');
        menuIcon.classList.remove('hidden');
        menuIcon.classList.add('block');
        closeIcon.classList.add('hidden');
        closeIcon.classList.remove('block');
        mobileMenuButton.setAttribute('aria-expanded', 'false');
      }
    }
  });
</script>