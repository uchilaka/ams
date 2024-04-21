import React from 'react'
import { CookiesProvider } from 'react-cookie'
import { Outlet } from 'react-router-dom'

import SessionProvider from './SessionProvider'

export default function Root() {
  return (
    <CookiesProvider>
      <SessionProvider>
        <Outlet />
      </SessionProvider>
    </CookiesProvider>
  )
}
