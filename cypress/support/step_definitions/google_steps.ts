/// <reference types="Cypress" />

import { Given, Then, When } from "cypress-cucumber-preprocessor/steps";
import GooglePage from "../page_objects/google_page";

const googlePage = new GooglePage();

Cypress.on("uncaught:exception", (err, runnable) => {
  return false;
});

Given('que eu acesso a página do Google', () => {
  cy.viewport(1366, 768);
  cy.visit('/');
})

When("informo o {string} no campo de busca",
  term => {
    googlePage.fillInputSearch(term);
  }
);


When("clico no botão Pesquisa Google", () => {
  googlePage.clickOnSearch();
});


Then("devo visualizar os resultados do termo",
  () => {
    
  }
);