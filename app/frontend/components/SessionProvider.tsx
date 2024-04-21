import React from 'react'
// Usage docs: https://github.com/bendotcodes/cookies/tree/main/packages/react-cookie
import { useCookies } from 'react-cookie'

import { AppCookies, CookieSetOptions, User } from '../types'

export interface SessionContextProps<T = '_account_manager_session'> {
  user?: User
  cookies: AppCookies
  setCookie: (name: T, value: string | Object, options?: CookieSetOptions | undefined) => void
  removeCookie: (name: T, options?: CookieSetOptions | undefined) => void
}

interface SessionProviderProps {
  children?: React.ReactNode
}

const SessionContext = React.createContext<SessionContextProps>(null!)

export default function SessionProvider({ children }: SessionProviderProps) {
  const [cookies, setCookie, removeCookie] = useCookies(['_account_manager_session'])

  return <SessionContext.Provider value={{ cookies, setCookie, removeCookie }}>{children}</SessionContext.Provider>
}
