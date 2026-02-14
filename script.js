// ═══════════════════════════════════════════
// Konstantinos Gkekas - Portfolio Scripts
// ═══════════════════════════════════════════

document.addEventListener('DOMContentLoaded', () => {

  // ── Particle Canvas ─────────────────────
  const canvas = document.getElementById('particles');
  const ctx = canvas.getContext('2d');
  let w, h, dots = [];

  function resize() {
    w = canvas.width = window.innerWidth;
    h = canvas.height = window.innerHeight;
  }
  window.addEventListener('resize', resize);
  resize();

  class Dot {
    constructor() { this.reset(); }
    reset() {
      this.x = Math.random() * w;
      this.y = Math.random() * h;
      this.vx = (Math.random() - 0.5) * 0.3;
      this.vy = (Math.random() - 0.5) * 0.3;
      this.r = Math.random() * 1.5 + 0.5;
    }
    update() {
      this.x += this.vx;
      this.y += this.vy;
      if (this.x < 0 || this.x > w) this.vx *= -1;
      if (this.y < 0 || this.y > h) this.vy *= -1;
    }
    draw() {
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(168, 85, 247, 0.35)';
      ctx.fill();
    }
  }

  const count = Math.min(80, Math.floor(w * h / 15000));
  for (let i = 0; i < count; i++) dots.push(new Dot());

  function connectDots() {
    for (let i = 0; i < dots.length; i++) {
      for (let j = i + 1; j < dots.length; j++) {
        const dx = dots[i].x - dots[j].x;
        const dy = dots[i].y - dots[j].y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < 140) {
          ctx.beginPath();
          ctx.moveTo(dots[i].x, dots[i].y);
          ctx.lineTo(dots[j].x, dots[j].y);
          ctx.strokeStyle = 'rgba(168, 85, 247,' + (0.08 * (1 - dist / 140)) + ')';
          ctx.lineWidth = 0.5;
          ctx.stroke();
        }
      }
    }
  }

  function animateParticles() {
    ctx.clearRect(0, 0, w, h);
    dots.forEach(d => { d.update(); d.draw(); });
    connectDots();
    requestAnimationFrame(animateParticles);
  }
  animateParticles();

  // ── Scroll-Reveal (with stagger support) ─
  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -60px 0px' });

  document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));

  // ── Typed Text Animation ────────────────
  const titles = [
    'Senior Cloud Operations Engineer',
    'AWS Solutions Architect',
    'Infrastructure Automation Specialist',
    'DevOps Engineer',
    'Kubernetes & Container Expert',
  ];
  const typedEl = document.getElementById('typed-text');
  let titleIdx = 0, charIdx = 0, isDeleting = false;

  function typeLoop() {
    const current = titles[titleIdx];
    if (!isDeleting) {
      typedEl.textContent = current.substring(0, charIdx + 1);
      charIdx++;
      if (charIdx === current.length) {
        isDeleting = true;
        setTimeout(typeLoop, 2000);       // pause before deleting
        return;
      }
      setTimeout(typeLoop, 70);           // typing speed
    } else {
      typedEl.textContent = current.substring(0, charIdx - 1);
      charIdx--;
      if (charIdx === 0) {
        isDeleting = false;
        titleIdx = (titleIdx + 1) % titles.length;
        setTimeout(typeLoop, 400);        // pause before next word
        return;
      }
      setTimeout(typeLoop, 35);           // deleting speed
    }
  }
  typeLoop();

  // ── Animated Counters ───────────────────
  const counterObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const el = entry.target;
        const target = +el.getAttribute('data-target');
        const duration = 1800;
        const start = performance.now();

        function tick(now) {
          const progress = Math.min((now - start) / duration, 1);
          const eased = 1 - Math.pow(1 - progress, 3);   // ease-out cubic
          el.textContent = Math.floor(eased * target) + '+';
          if (progress < 1) requestAnimationFrame(tick);
        }
        requestAnimationFrame(tick);
        counterObserver.unobserve(el);
      }
    });
  }, { threshold: 0.5 });

  document.querySelectorAll('.counter').forEach(el => counterObserver.observe(el));

  // ── Back to Top Button ──────────────────
  const backToTop = document.getElementById('back-to-top');
  if (backToTop) {
    window.addEventListener('scroll', () => {
      if (window.scrollY > 500) {
        backToTop.classList.add('visible');
      } else {
        backToTop.classList.remove('visible');
      }
    }, { passive: true });

    backToTop.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  // ── Active Nav Highlighting ─────────────
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.nav-link');

  function highlightNav() {
    const scrollY = window.scrollY + 200;
    sections.forEach(section => {
      const top = section.offsetTop;
      const height = section.offsetHeight;
      const id = section.getAttribute('id');
      if (scrollY >= top && scrollY < top + height) {
        navLinks.forEach(link => {
          link.classList.remove('active');
          if (link.getAttribute('href') === '#' + id) link.classList.add('active');
        });
      }
    });
  }
  window.addEventListener('scroll', highlightNav, { passive: true });
  highlightNav();

  // ── Navbar Background on Scroll ─────────
  const navbar = document.getElementById('navbar');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
      navbar.classList.add('shadow-lg');
      navbar.style.background = 'rgba(11, 15, 26, 0.95)';
    } else {
      navbar.classList.remove('shadow-lg');
      navbar.style.background = '';
    }
  }, { passive: true });

  // ── Mobile Menu Toggle ──────────────────
  const menuBtn = document.getElementById('menu-btn');
  const mobileMenu = document.getElementById('mobile-menu');
  const menuIcon = document.getElementById('menu-icon');

  if (menuBtn) {
    menuBtn.addEventListener('click', () => {
      mobileMenu.classList.toggle('hidden');
      const isOpen = !mobileMenu.classList.contains('hidden');
      menuBtn.setAttribute('aria-expanded', isOpen);
      menuIcon.setAttribute('d', isOpen
        ? 'M6 18L18 6M6 6l12 12'
        : 'M4 6h16M4 12h16M4 18h16'
      );
    });

    mobileMenu.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        mobileMenu.classList.add('hidden');
        menuIcon.setAttribute('d', 'M4 6h16M4 12h16M4 18h16');
      });
    });
  }

  // ── Smooth Scroll ───────────────────────
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

});
