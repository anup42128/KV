class ThemeManager{constructor(){this.init()}
init(){this.applySystemTheme();this.watchSystemPreference()}
applySystemTheme(){const prefersDark=window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches;const theme=prefersDark?'dark':'light';document.documentElement.setAttribute('data-theme',theme)}
watchSystemPreference(){if(window.matchMedia){const mediaQuery=window.matchMedia('(prefers-color-scheme: dark)');mediaQuery.addListener((e)=>{const theme=e.matches?'dark':'light';document.documentElement.setAttribute('data-theme',theme)})}}}
const themeManager=new ThemeManager();class ModalManager{constructor(){this.overlay=document.getElementById('modalOverlay');this.signUpModal=document.getElementById('signUpModal');this.logInModal=document.getElementById('logInModal');this.init()}
init(){document.getElementById('signUpBtn')?.addEventListener('click',()=>this.openModal('signup'));document.getElementById('logInBtn')?.addEventListener('click',()=>this.openModal('login'));document.getElementById('closeSignUp')?.addEventListener('click',()=>this.closeModal());document.getElementById('closeLogIn')?.addEventListener('click',()=>this.closeModal());document.getElementById('switchToLogin')?.addEventListener('click',(e)=>{e.preventDefault();this.switchModal('login')});document.getElementById('switchToSignUp')?.addEventListener('click',(e)=>{e.preventDefault();this.switchModal('signup')});this.overlay?.addEventListener('click',(e)=>{if(e.target===this.overlay){this.closeModal()}});document.addEventListener('keydown',(e)=>{if(e.key==='Escape'&&this.overlay?.classList.contains('active')){this.closeModal()}});document.getElementById('signUpForm')?.addEventListener('submit',(e)=>this.handleSignUp(e));document.getElementById('logInForm')?.addEventListener('submit',(e)=>this.handleLogIn(e))}
openModal(type){if(!this.overlay)return;this.signUpModal.style.display='none';this.logInModal.style.display='none';if(type==='signup'){this.signUpModal.style.display='block'}else{this.logInModal.style.display='block'}
this.overlay.style.display='flex';requestAnimationFrame(()=>{this.overlay.classList.add('active')});document.body.style.overflow='hidden'}
closeModal(){if(!this.overlay)return;this.overlay.classList.remove('active');setTimeout(()=>{this.overlay.style.display='none';this.clearForms()},300);document.body.style.overflow=''}
switchModal(type){this.signUpModal.style.display='none';this.logInModal.style.display='none';if(type==='signup'){this.signUpModal.style.display='block'}else{this.logInModal.style.display='block'}
this.clearForms()}
clearForms(){const forms=[document.getElementById('signUpForm'),document.getElementById('logInForm')];forms.forEach(form=>{if(form){form.reset();const inputs=form.querySelectorAll('.form-input');inputs.forEach(input=>{input.classList.remove('error','success')})}})}
async handleSignUp(e){e.preventDefault();const username=document.getElementById('signUpUsername').value;const password=document.getElementById('signUpPassword').value;const confirmPassword=document.getElementById('signUpConfirmPassword').value;if(!this.validateSignUp(username,password,confirmPassword)){return}
await this.processSignUp({username,password})}
async handleLogIn(e){e.preventDefault();const username=document.getElementById('logInUsername').value;const password=document.getElementById('logInPassword').value;if(!this.validateLogIn(username,password)){return}
await this.processLogIn({username,password})}
validateSignUp(username,password,confirmPassword){let isValid=!0;let validationErrors=[];const usernameInput=document.getElementById('signUpUsername');const passwordInput=document.getElementById('signUpPassword');const confirmPasswordInput=document.getElementById('signUpConfirmPassword');[usernameInput,passwordInput,confirmPasswordInput].forEach(input=>{input.classList.remove('error','success');const existingError=input.parentNode.querySelector('.error-message');if(existingError){existingError.remove()}});if(!username||username.trim().length===0){usernameInput.classList.add('error');this.showFieldError(usernameInput,'👤 Username is required');isValid=!1}else if(username.length<3){usernameInput.classList.add('error');this.showFieldError(usernameInput,'👤 Username must be at least 3 characters long');isValid=!1}else if(username.length>20){usernameInput.classList.add('error');this.showFieldError(usernameInput,'👤 Username cannot exceed 20 characters');isValid=!1}else if(!/^[a-zA-Z0-9_]+$/.test(username)){usernameInput.classList.add('error');this.showFieldError(usernameInput,'👤 Username can only contain letters, numbers, and underscores');isValid=!1}else if(/^[0-9_]/.test(username)){usernameInput.classList.add('error');this.showFieldError(usernameInput,'👤 Username must start with a letter');isValid=!1}else{usernameInput.classList.add('success')}
if(!password||password.length===0){passwordInput.classList.add('error');this.showFieldError(passwordInput,'🔒 Password is required');isValid=!1}else if(password.length<6){passwordInput.classList.add('error');this.showFieldError(passwordInput,'🔒 Password must be at least 6 characters long');isValid=!1}else if(password.length>100){passwordInput.classList.add('error');this.showFieldError(passwordInput,'🔒 Password cannot exceed 100 characters');isValid=!1}else{passwordInput.classList.add('success')}
if(!confirmPassword||confirmPassword.length===0){confirmPasswordInput.classList.add('error');this.showFieldError(confirmPasswordInput,'🔑 Please confirm your password');isValid=!1}else if(password!==confirmPassword){confirmPasswordInput.classList.add('error');this.showFieldError(confirmPasswordInput,'🔑 Passwords do not match');isValid=!1}else if(confirmPassword.length>0){confirmPasswordInput.classList.add('success')}
return isValid}
validateLogIn(username,password){let isValid=!0;const usernameInput=document.getElementById('logInUsername');const passwordInput=document.getElementById('logInPassword');[usernameInput,passwordInput].forEach(input=>{input.classList.remove('error','success');const existingError=input.parentNode.querySelector('.error-message');if(existingError){existingError.remove()}});if(!username||username.trim().length===0){usernameInput.classList.add('error');this.showFieldError(usernameInput,'👤 Please enter your username');isValid=!1}else if(username.length<3){usernameInput.classList.add('error');this.showFieldError(usernameInput,'👤 Username must be at least 3 characters');isValid=!1}else{usernameInput.classList.add('success')}
if(!password||password.length===0){passwordInput.classList.add('error');this.showFieldError(passwordInput,'🔒 Please enter your password');isValid=!1}else if(password.length<6){passwordInput.classList.add('error');this.showFieldError(passwordInput,'🔒 Password must be at least 6 characters');isValid=!1}else{passwordInput.classList.add('success')}
return isValid}
showFieldError(input,message){const errorDiv=document.createElement('div');errorDiv.className='error-message';errorDiv.innerHTML=`<span style="color: #dc3545; font-size: 12px; margin-top: 5px; display: block;">${message}</span>`;input.parentNode.appendChild(errorDiv);input.style.animation='inputShake 0.3s ease-in-out';setTimeout(()=>{input.style.animation=''},300)}
async processSignUp(data){const submitBtn=document.querySelector('#signUpForm .form-btn');try{submitBtn.classList.add('loading');submitBtn.disabled=!0;if(!window.DatabaseHelper){throw new Error('Database connection not available')}
const result=await window.DatabaseHelper.createUser({username:data.username,password:data.password,user_type:'student'});submitBtn.classList.remove('loading');submitBtn.disabled=!1;if(result.success){this.showMessage(result.message,'success');let sessionToken=null;if(window.DatabaseHelper&&window.DatabaseHelper.createSession){sessionToken=await window.DatabaseHelper.createSession(result.user.id)}
if(window.SessionManager){window.SessionManager.setUserSession(result.user.username,sessionToken);setTimeout(()=>{this.closeModal();window.SessionManager.redirectAfterLogin()},1500)}else{setTimeout(()=>{this.closeModal();window.location.href=`dashboard.html?username=${encodeURIComponent(result.user.username)}`},1500)}}else{if(result.error&&result.error.toLowerCase().includes('username already exists')){const usernameInput=document.getElementById('signUpUsername');usernameInput.classList.remove('success');usernameInput.classList.add('error');this.showFieldError(usernameInput,'👤 This username is already taken. Please choose another.')}else{this.showMessage(result.error||'Failed to create account. Please try again.','error')}}}catch(error){console.error('❌ Signup process failed:',error);submitBtn.classList.remove('loading');submitBtn.disabled=!1;this.showMessage('Failed to create account. Please try again.','error')}}
async processLogIn(data){const submitBtn=document.querySelector('#logInForm .form-btn');try{submitBtn.classList.add('loading');submitBtn.disabled=!0;if(!window.DatabaseHelper){throw new Error('Database connection not available')}
const result=await window.DatabaseHelper.authenticateUser(data.username,data.password);submitBtn.classList.remove('loading');submitBtn.disabled=!1;if(result.success){this.showMessage(result.message,'success');let sessionToken=null;if(window.DatabaseHelper&&window.DatabaseHelper.createSession){sessionToken=await window.DatabaseHelper.createSession(result.user.id)}
if(window.SessionManager){window.SessionManager.setUserSession(result.user.username,sessionToken);setTimeout(()=>{this.closeModal();window.SessionManager.redirectAfterLogin()},1500)}else{sessionStorage.setItem('currentUsername',result.user.username);console.log('💾 Saved username to session:',result.user.username);setTimeout(()=>{this.closeModal();window.location.href=`dashboard.html?username=${encodeURIComponent(result.user.username)}`},1500)}}else{this.showMessage(result.error,'error');const form=document.getElementById('logInForm');form.style.animation='shake 0.5s ease-in-out';setTimeout(()=>{form.style.animation=''},500)}}catch(error){console.error('❌ Login process failed:',error);submitBtn.classList.remove('loading');submitBtn.disabled=!1;this.showMessage('Login failed. Please check your connection and try again.','error')}}
showMessage(text,type='info'){const message=document.createElement('div');message.className=`modal-message modal-message-${type}`;message.innerHTML=`
            <span class="message-icon">${type === 'success' ? '✅' : type === 'error' ? '❌' : 'ℹ️'}</span>
            <span class="message-text">${text}</span>
        `;message.style.cssText=`
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#3b82f6'};
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            box-shadow: var(--shadow-heavy);
            z-index: 10000;
            display: flex;
            align-items: center;
            gap: 10px;
            transform: translateX(100%);
            transition: transform 0.3s ease;
            font-weight: 500;
        `;document.body.appendChild(message);requestAnimationFrame(()=>{message.style.transform='translateX(0)'});setTimeout(()=>{message.style.transform='translateX(100%)';setTimeout(()=>{document.body.removeChild(message)},300)},3000)}}
const modalManager=new ModalManager();document.addEventListener('DOMContentLoaded',function(){const initSupabase=()=>{if(window.supabase&&typeof initializeSupabase==='function'){const success=initializeSupabase();if(success){console.log('✅ Database connection ready');if(window.DatabaseHelper){window.DatabaseHelper.testConnection()}}else{console.error('❌ Failed to initialize Supabase')}}else{setTimeout(initSupabase,100)}};initSupabase()});document.addEventListener('DOMContentLoaded',function(){const observerOptions={threshold:0.1,rootMargin:'0px 0px -50px 0px'};const observer=new IntersectionObserver((entries)=>{entries.forEach(entry=>{if(entry.isIntersecting){entry.target.classList.add('visible');if(entry.target.classList.contains('about-stats')){animateCounters()}
if(entry.target.classList.contains('features-grid')){staggerFeatureCards()}
if(entry.target.classList.contains('steps-container')){staggerSteps()}}})},observerOptions);const sections=document.querySelectorAll('section');sections.forEach(section=>{section.classList.add('scroll-fade');observer.observe(section)});const animatedElements=document.querySelectorAll('.about-stats, .features-grid, .steps-container');animatedElements.forEach(element=>{observer.observe(element)});function animateCounters(){const counters=document.querySelectorAll('.stat-number');counters.forEach(counter=>{const target=counter.textContent;if(target.includes('+')){const number=parseInt(target.replace('+',''));animateCounter(counter,number,'+')}else if(target==='Daily'){return}})}
function animateCounter(element,target,suffix=''){let current=0;const increment=target/50;const timer=setInterval(()=>{current+=increment;if(current>=target){element.textContent=target+suffix;clearInterval(timer)}else{element.textContent=Math.floor(current)+suffix}},30)}
function staggerFeatureCards(){const cards=document.querySelectorAll('.feature-card');cards.forEach((card,index)=>{setTimeout(()=>{card.style.opacity='0';card.style.transform='translateY(30px)';card.style.transition='all 0.6s ease';setTimeout(()=>{card.style.opacity='1';card.style.transform='translateY(0)'},50)},index*150)})}
function staggerSteps(){const steps=document.querySelectorAll('.step-item');const arrows=document.querySelectorAll('.step-arrow');steps.forEach((step,index)=>{setTimeout(()=>{step.style.opacity='0';step.style.transform='translateY(30px)';step.style.transition='all 0.6s ease';setTimeout(()=>{step.style.opacity='1';step.style.transform='translateY(0)'},50)},index*200)});arrows.forEach((arrow,index)=>{setTimeout(()=>{arrow.style.opacity='0';arrow.style.transition='opacity 0.6s ease';setTimeout(()=>{arrow.style.opacity='1'},50)},(index+1)*200)})}
window.addEventListener('scroll',()=>{const scrolled=window.pageYOffset;const rate=scrolled*-0.5;document.querySelectorAll('.floating-shape').forEach((shape,index)=>{const speed=(index+1)*0.3;shape.style.transform=`translateY(${rate * speed}px)`})});const buttons=document.querySelectorAll('.btn');buttons.forEach(button=>{button.addEventListener('click',function(e){const ripple=document.createElement('span');const rect=this.getBoundingClientRect();const size=Math.max(rect.width,rect.height);const x=e.clientX-rect.left-size/2;const y=e.clientY-rect.top-size/2;ripple.style.position='absolute';ripple.style.width=ripple.style.height=size+'px';ripple.style.left=x+'px';ripple.style.top=y+'px';ripple.style.background='rgba(255, 255, 255, 0.3)';ripple.style.borderRadius='50%';ripple.style.transform='scale(0)';ripple.style.animation='ripple 0.6s ease-out';this.appendChild(ripple);setTimeout(()=>{ripple.remove()},600)})});const style=document.createElement('style');style.textContent=`
        @keyframes ripple {
            to {
                transform: scale(2);
                opacity: 0;
            }
        }
        
        @keyframes inputShake {
            0%, 100% { transform: translateX(0); }
            10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
            20%, 40%, 60%, 80% { transform: translateX(5px); }
        }
        
        .form-input.error {
            border-color: #dc3545 !important;
            box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25) !important;
        }
        
        .form-input.success {
            border-color: #28a745 !important;
            box-shadow: 0 0 0 0.2rem rgba(40, 167, 69, 0.25) !important;
        }
        
        .error-message {
            animation: fadeInError 0.3s ease-in-out;
        }
        
        @keyframes fadeInError {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    `;document.head.appendChild(style);const cards=document.querySelectorAll('.feature-card, .icon-item');cards.forEach(card=>{card.addEventListener('mouseenter',function(e){this.style.transition='all 0.3s ease'});card.addEventListener('mousemove',function(e){const rect=this.getBoundingClientRect();const x=e.clientX-rect.left;const y=e.clientY-rect.top;const centerX=rect.width/2;const centerY=rect.height/2;const rotateX=(y-centerY)/10;const rotateY=(centerX-x)/10;this.style.transform=`translateY(-10px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`});card.addEventListener('mouseleave',function(){this.style.transform='translateY(0) rotateX(0) rotateY(0)'})});function createParticle(){const particle=document.createElement('div');const isDark=document.documentElement.getAttribute('data-theme')==='dark';particle.style.position='fixed';particle.style.width='4px';particle.style.height='4px';particle.style.background=isDark?'rgba(147, 197, 253, 0.6)':'rgba(255, 255, 255, 0.6)';particle.style.borderRadius='50%';particle.style.pointerEvents='none';particle.style.zIndex='-1';particle.style.left=Math.random()*window.innerWidth+'px';particle.style.top=window.innerHeight+'px';particle.style.animation='particleRise 8s linear forwards';document.body.appendChild(particle);setTimeout(()=>{particle.remove()},8000)}
setInterval(createParticle,2000);const particleStyle=document.createElement('style');particleStyle.textContent=`
        @keyframes particleRise {
            to {
                transform: translateY(-${window.innerHeight + 100}px) translateX(${Math.random() * 200 - 100}px);
                opacity: 0;
            }
        }
    `;document.head.appendChild(particleStyle);document.addEventListener('click',function(e){if(e.target.matches('a[href^="#"]')){e.preventDefault();const targetId=e.target.getAttribute('href');const targetElement=document.querySelector(targetId);if(targetElement){targetElement.scrollIntoView({behavior:'smooth',block:'start'})}}});document.body.style.opacity='0';document.body.style.transition='opacity 0.5s ease-in-out';window.addEventListener('load',()=>{document.body.style.opacity='1'});let isVisible=!0;document.addEventListener('visibilitychange',()=>{isVisible=!document.hidden;const animations=document.querySelectorAll('.floating-shape, .logo-circle');animations.forEach(element=>{element.style.animationPlayState=isVisible?'running':'paused'})});if('ontouchstart' in window){const touchElements=document.querySelectorAll('.btn, .feature-card, .step-item');touchElements.forEach(element=>{element.addEventListener('touchstart',function(){this.classList.add('touch-active')});element.addEventListener('touchend',function(){setTimeout(()=>{this.classList.remove('touch-active')},150)})});const touchStyle=document.createElement('style');touchStyle.textContent=`
            .touch-active {
                transform: scale(0.98) !important;
                transition: transform 0.1s ease !important;
            }
        `;document.head.appendChild(touchStyle)}
let konamiCode=[];const konamiSequence=[38,38,40,40,37,39,37,39,66,65];document.addEventListener('keydown',(e)=>{konamiCode.push(e.keyCode);if(konamiCode.length>konamiSequence.length){konamiCode.shift()}
if(JSON.stringify(konamiCode)===JSON.stringify(konamiSequence)){triggerConfetti();konamiCode=[]}});function triggerConfetti(){const isDark=document.documentElement.getAttribute('data-theme')==='dark';const colors=isDark?['#fb923c','#60a5fa','#a855f7']:['#f97316','#3b82f6','#7c3aed'];for(let i=0;i<50;i++){setTimeout(()=>{const confetti=document.createElement('div');confetti.style.position='fixed';confetti.style.width='10px';confetti.style.height='10px';confetti.style.background=colors[Math.floor(Math.random()*colors.length)];confetti.style.left=Math.random()*window.innerWidth+'px';confetti.style.top='-10px';confetti.style.zIndex='9999';confetti.style.animation='confettiFall 3s linear forwards';confetti.style.borderRadius='50%';document.body.appendChild(confetti);setTimeout(()=>{confetti.remove()},3000)},i*50)}
const confettiStyle=document.createElement('style');confettiStyle.textContent=`
            @keyframes confettiFall {
                to {
                    transform: translateY(${window.innerHeight + 100}px) rotate(720deg);
                }
            }
        `;document.head.appendChild(confettiStyle)}
console.log('🎉 PM SHRI KV Barrackpore Feedback Portal loaded successfully!');console.log('💡 Try the Konami code for a surprise: ↑↑↓↓←→←→BA');console.log('🌓 Auto theme system initialized - follows your system preference!');console.log('🔄 Theme automatically switches with your system dark/light mode')})
