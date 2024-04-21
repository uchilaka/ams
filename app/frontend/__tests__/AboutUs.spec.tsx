import React from 'react'
import { describe, test, it, expect } from '@jest/globals'
import { render, screen } from '@testing-library/react'
// import { screen } from '@testing-library/dom'

import AboutUs from '@/routes/AboutUs'

describe('AboutUs', () => {
  test('should render the AboutUs page', async () => {
    render(<AboutUs />)
    const heading = await screen.findByRole('title')
    expect(heading.textContent).toContain('This is the about us component')
  })
})
