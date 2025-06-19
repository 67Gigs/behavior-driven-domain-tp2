using System;
using System.Collections.Generic;
using System.Linq;
using TechTalk.SpecFlow;
using TechTalk.SpecFlow.Assist;
using NUnit.Framework;

namespace SpecFlowScrutin.Specs.Steps;

[Binding]
public class ScrutinStepDefinitions
{
    private Scrutin _scrutin;
    private ResultatScrutin _resultat;
    private Exception _exception;

    [Given(@"un scrutin majoritaire existe")]
    public void GivenUnScrutinMajoritaireExiste()
    {
        _scrutin = new Scrutin();
    }

    [Given(@"les candidats suivants sont enregistrés:")]
    public void GivenLesCandidatsSuivantsSONTEnregistres(Table table)
    {
        foreach (var row in table.Rows)
        {
            _scrutin.AjouterCandidat(row["Nom"]);
        }
    }

    [Given(@"le scrutin est au tour (.*)")]
    public void GivenLeScrutinEstAuTour(int tour)
    {
        _scrutin.DefinirTour(tour);
    }

    [Given(@"les votes suivants ont été enregistrés:")]
    public void GivenLesVotesSuivantsOntEteEnregistres(Table table)
    {
        foreach (var row in table.Rows)
        {
            var candidat = row["Candidat"];
            var votes = int.Parse(row["Votes"]);
            _scrutin.EnregistrerVotes(candidat, votes);
        }
    }

    [Given(@"les candidats qualifiés sont:")]
    public void GivenLesCandidatsQualifiesSont(Table table)
    {
        var candidatsQualifies = table.Rows.Select(row => row["Candidat"]).ToList();
        _scrutin.DefinirCandidatsQualifies(candidatsQualifies);
    }

    [When(@"je clôture le scrutin")]
    public void WhenJeClotureLescrutin()
    {
        try
        {
            _resultat = _scrutin.CloturerEtCalculerResultat();
        }
        catch (Exception ex)
        {
            _exception = ex;
        }
    }

    [When(@"je tente de calculer le résultat sans clôturer le scrutin")]
    public void WhenJeTenteDeCalculerLeResultatSansCloturerLeScrutin()
    {
        try
        {
            _resultat = _scrutin.CalculerResultatSansCloturer();
        }
        catch (Exception ex)
        {
            _exception = ex;
        }
    }

    [Then(@"le scrutin doit être clôturé")]
    public void ThenLeScrutinDoitEtreCloture()
    {
        Assert.IsTrue(_scrutin.EstCloture);
    }

    [Then(@"le vainqueur doit être ""(.*)""")]
    public void ThenLeVainqueurDoitEtre(string vainqueur)
    {
        Assert.AreEqual(vainqueur, _resultat.Vainqueur);
    }

    [Then(@"aucun vainqueur ne doit être déterminé")]
    public void ThenAucunVainqueurNeDoitEtreDetermine()
    {
        Assert.IsNull(_resultat.Vainqueur);
    }

    [Then(@"les résultats doivent afficher:")]
    public void ThenLesResultatsDoiventAfficher(Table table)
    {
        foreach (var row in table.Rows)
        {
            var candidat = row["Candidat"];
            var votesAttendu = int.Parse(row["Votes"]);
            var pourcentageAttendu = decimal.Parse(row["Pourcentage"].Replace("%", ""));

            var resultatCandidat = _resultat.ResultatsParCandidat.First(r => r.Candidat == candidat);
            
            Assert.AreEqual(votesAttendu, resultatCandidat.Votes, $"Votes incorrects pour {candidat}");
            Assert.That(resultatCandidat.Pourcentage, Is.EqualTo(pourcentageAttendu).Within(0.01m), $"Pourcentage incorrect pour {candidat}");
        }
    }

    [Then(@"les candidats qualifiés pour le second tour doivent être:")]
    public void ThenLesCandidatsQualifiesPourLeSecondTourDoiventEtre(Table table)
    {
        var candidatsAttendus = table.Rows.Select(row => row["Candidat"]).ToList();
        CollectionAssert.AreEquivalent(candidatsAttendus, _resultat.CandidatsQualifiesSecondTour);
    }

    [Then(@"une exception doit être levée avec le message ""(.*)""")]
    public void ThenUneExceptionDoitEtreLeveeAvecLeMessage(string message)
    {
        Assert.IsNotNull(_exception);
        Assert.AreEqual(message, _exception.Message);
    }

    [Then(@"le message doit indiquer ""(.*)""")]
    public void ThenLeMessageDoitIndiquer(string message)
    {
        Assert.AreEqual(message, _resultat.Message);
    }

    [Given(@"un scrutin majoritaire avec un seul candidat existe")]
    public void GivenUnScrutinMajoritaireAvecUnSeulCandidatExiste()
    {
        _scrutin = new Scrutin();
    }

    [Given(@"le candidat ""(.*)"" est enregistré")]
    public void GivenLeCandidatEstEnregistre(string candidat)
    {
        _scrutin.AjouterCandidat(candidat);
    }

    [Given(@"le scrutin a été clôturé")]
    public void GivenLeScrutinAEteCloture()
    {
        _scrutin.CloturerEtCalculerResultat();
    }

    [Given(@"je modifie les votes pour ""(.*)"" à (.*)")]
    public void GivenJeModifieLeVotesPourA(string candidat, int votes)
    {
        _scrutin.EnregistrerVotes(candidat, votes);
    }

    [When(@"je tente d'enregistrer des votes supplémentaires pour ""(.*)"" avec (.*) votes")]
    public void WhenJeTenteDenregistrerDesVotesSupplementairesPourAvecVotes(string candidat, int votes)
    {
        try
        {
            _scrutin.EnregistrerVotes(candidat, votes);
        }
        catch (Exception ex)
        {
            _exception = ex;
        }
    }

    [When(@"je tente d'enregistrer des votes pour un candidat inexistant ""(.*)"" avec (.*) votes")]
    public void WhenJeTenteDenregistrerDesVotesPourUnCandidatInexistantAvecVotes(string candidat, int votes)
    {
        try
        {
            _scrutin.EnregistrerVotes(candidat, votes);
        }
        catch (Exception ex)
        {
            _exception = ex;
        }
    }

    [When(@"je tente de définir le tour à (.*)")]
    public void WhenJeTenteDeDefinirLeTourA(int tour)
    {
        try
        {
            _scrutin.DefinirTour(tour);
        }
        catch (Exception ex)
        {
            _exception = ex;
        }
    }

    [Then(@"les candidats doivent être ordonnés par nombre de votes décroissant:")]
    public void ThenLesCandidatsDoiventEtreOrdonnesParNombreDeVotesDecroissant(Table table)
    {
        var resultatsOrdonnes = _resultat.ResultatsParCandidat.ToList();
        
        for (int i = 0; i < table.Rows.Count; i++)
        {
            var row = table.Rows[i];
            var positionAttendue = int.Parse(row["Position"]) - 1; // Index 0-based
            var candidatAttendu = row["Candidat"];
            var votesAttendus = int.Parse(row["Votes"]);
            
            Assert.AreEqual(candidatAttendu, resultatsOrdonnes[positionAttendue].Candidat, 
                $"Candidat incorrect à la position {positionAttendue + 1}");
            Assert.AreEqual(votesAttendus, resultatsOrdonnes[positionAttendue].Votes, 
                $"Votes incorrects pour {candidatAttendu}");
        }
    }

    [Then(@"le tour actuel doit être (.*)")]
    public void ThenLeTourActuelDoitEtre(int tour)
    {
        Assert.AreEqual(tour, _scrutin.TourActuel);
    }

    [Then(@"aucune modification ne doit être possible")]
    public void ThenAucuneModificationNeDoitEtrePossible()
    {
        Assert.IsTrue(_scrutin.EstCloture);
        
        // Vérifier qu'on ne peut plus ajouter de votes
        try
        {
            _scrutin.EnregistrerVotes("Candidat A", 100);
            Assert.Fail("Une exception aurait dû être levée");
        }
        catch (InvalidOperationException)
        {
            // Comportement attendu
        }
    }

    [Then(@"aucun troisième tour ne doit être possible")]
    public void ThenAucunTroisiemeTourNeDoitEtrePossible()
    {
        Assert.AreEqual(2, _scrutin.TourActuel);
        Assert.IsTrue(_scrutin.EstCloture);
    }

    [Given(@"(.*) votes blancs ont été enregistrés")]
    public void GivenVotesBlansOntEteEnregistres(int votesBlancs)
    {
        _scrutin.EnregistrerVotesBlancs(votesBlancs);
    }

    [When(@"je tente d'enregistrer (.*) votes blancs après clôture")]
    public void WhenJeTenteDenregistrerVotesBlansApresClôture(int votesBlancs)
    {
        try
        {
            _scrutin.EnregistrerVotesBlancs(votesBlancs);
        }
        catch (Exception ex)
        {
            _exception = ex;
        }
    }

    [Then(@"le nombre de votes blancs doit être (.*)")]
    public void ThenLeNombreDeVotesBlansDoitEtre(int votesBlancs)
    {
        Assert.AreEqual(votesBlancs, _resultat.VotesBlancs);
    }

    [Then(@"le total des votes exprimés doit être (.*)")]
    public void ThenLeTotalDesVotesExprimesDoitEtre(int totalVotes)
    {
        Assert.AreEqual(totalVotes, _resultat.TotalVotesExprimes);
    }

    [Then(@"les candidats qualifiés doivent être dans l'ordre alphabétique en cas d'égalité:")]
    public void ThenLesCandidatsQualifiesDoiventEtreDansLordreAlphabetiqueEnCasEgalite(Table table)
    {
        var candidatsAttendus = table.Rows.Select(row => row["Candidat"]).ToList();
        CollectionAssert.AreEqual(candidatsAttendus, _resultat.CandidatsQualifiesSecondTour);
    }
}

// Classes de support pour les données
public class CandidatData
{
    public string Nom { get; set; }
}

public class VoteData
{
    public string Candidat { get; set; }
    public int Votes { get; set; }
}