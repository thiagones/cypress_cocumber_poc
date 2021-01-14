/// <reference types="cypress" />
// @ts-check

import { googleElements } from "../elements/google_elements";

export default class GooglePage {
  validatePageGoogle(): void {
    cy.get(googleElements.google.botaoPesquisaGoogle)
      .should("be.visible");
  }

  validateInput(): void {
    cy.get(googleElements.google.inputSearch, {timeout:10000})
      .should("be.visible")
  }

  fillInputSearch(term: string): void {
    cy.get(googleElements.google.inputSearch, {timeout: 15000})
      .should("be.visible")
      .type(term);
  }

  clickOnSearch() {
    cy.get(googleElements.google.botaoPesquisaGoogle, { timeout: 20000 })
      .should("be.visible")
      .click({force:true});
  }

}
