# PM SHRI Kendriya Vidyalaya Barrackpore (AFS) Feedback Portal

A modern, responsive, and animated landing page for the school feedback portal.

## 🎯 Features

- **Modern Design**: Clean, professional interface with KV theme colors (Blue, White, Orange)
- **Dark/Light Mode**: Automatic system preference detection
- **Responsive Layout**: Fully optimized for desktop, tablet, and mobile devices
- **Smooth Animations**: 
  - Floating background shapes
  - Gradient animations (theme-aware)
  - Scroll-triggered fade-ins
  - Hover effects with tilt
  - Button ripple effects
  - Counter animations
  - Theme-aware particle system
- **Auto Theme System**:
  - Automatic system preference detection
  - Real-time switching with system changes
  - Smooth transitions between themes
  - No manual intervention required

## 🎨 Design Elements

### Color Scheme
**Light Mode:**
- Primary Blue: #1e3a8a
- Secondary Blue: #3b82f6
- Accent Orange: #f97316
- White: #ffffff
- Purple: #7c3aed

**Dark Mode:**
- Primary Blue: #3b82f6
- Secondary Blue: #60a5fa
- Accent Orange: #fb923c
- Background: #0f172a
- Cards: #1e293b
- Text: #f1f5f9

### Fonts
- **Primary**: Poppins (Google Fonts)
- **Weights**: 300, 400, 500, 600, 700

### Sections
1. **Hero Section**: Welcome message with CTA buttons
2. **About Section**: Portal description with stats and icons
3. **Features Section**: Key portal features in card layout
4. **How It Works**: 4-step process guide
5. **Footer**: Contact info and school details

## 🚀 Getting Started

1. Open `index.html` in any modern web browser
2. The page will automatically match your system's theme preference
3. Theme will update automatically when you change your system settings
4. All animations are optimized for performance

## 📱 Responsive Breakpoints

- **Desktop**: 1200px+ (Full layout)
- **Tablet**: 768px - 1199px (Adjusted grid)
- **Mobile**: 320px - 767px (Single column, optimized touch)

## ✨ Interactive Features

- **Auto Theme Detection**: Automatically follows system dark/light mode preference
- **Hover Effects**: Cards lift and tilt on mouse interaction
- **Smooth Scrolling**: Animated transitions between sections
- **Button Animations**: Ripple effects and micro-interactions
- **Parallax**: Floating shapes move with scroll
- **Performance**: Animations pause when tab is not active
- **Real-time Theme Updates**: Changes instantly with system preference

## 🎮 Easter Eggs

- **Konami Code**: Try the classic ↑↑↓↓←→←→BA sequence for a surprise!
- **Dynamic Backgrounds**: Animated gradient shifts
- **Particle Effects**: Subtle floating particles

## 📂 File Structure

```
KV/
├── index.html          # Main HTML file
├── styles.css          # Complete CSS with animations
├── script.js           # JavaScript for interactions
└── README.md          # This file
```

## 🔧 Customization

### Changing Colors
Edit the CSS variables in `styles.css`:
```css
/* Light mode colors */
:root {
    --primary-blue: #1e3a8a;
    --accent-orange: #f97316;
    /* ... other variables */
}

/* Dark mode colors */
[data-theme="dark"] {
    --primary-blue: #3b82f6;
    --accent-orange: #fb923c;
    /* ... other variables */
}
```

### Auto Theme System
The theme system automatically:
- Detects system preference on page load
- Monitors system changes in real-time
- Applies smooth transitions when system theme changes
- Updates all animations and effects for the current theme
- No user interaction or storage required

### Adding New Sections
Follow the existing pattern with:
- Section wrapper with appropriate class
- Container for responsive layout
- Section header with title and subtitle
- Content grid or flex layout

## 🌐 Browser Compatibility

- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

## 📝 Notes

- No external dependencies except Google Fonts
- All animations use CSS transforms for optimal performance
- Images use emoji for universal compatibility
- Accessibility features included (focus states, proper contrast)

---

**Made for PM SHRI Kendriya Vidyalaya Barrackpore (AFS)**
