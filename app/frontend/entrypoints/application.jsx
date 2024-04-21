import 'flowbite'
import 'trix'
import '@rails/actiontext'

import './main.scss'

import { createElement } from 'react'
import { createRoot } from 'react-dom/client'
import Home from '@/views/home'
import Dashboard from '@/views/dashboard'

function mountIfContainerIsLoaded(containerId, Component) {
  const domContainer = document.querySelector(`#${containerId}`)
  if (domContainer) {
    const component = createRoot(domContainer)
    component.render(createElement(Component))
  }
}

window.addEventListener('DOMContentLoaded', () => {
  console.debug('DOM fully loaded and parsed')
  mountIfContainerIsLoaded('home', Home)
  mountIfContainerIsLoaded('dashboard', Dashboard)
})

window.addEventListener('load', () => {
  console.debug('Page is fully loaded')
})
