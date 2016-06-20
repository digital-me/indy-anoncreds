from anoncreds.protocol.utils import encodeAttrs
from anoncreds.protocol.prover import Prover


def getPresentationToken(issuers, prover, encodedAttrs):
    presentationToken = {}
    for key, val in prover.U.items():
        issuer = issuers[key]
        A, e, vprimeprime = issuer.issue(prover.U[key], encodedAttrs[key])
        v = prover.vprime[key] + vprimeprime
        presentationToken[key] = {"A": A, "e": e, "v": v}
    return presentationToken


def getProver(attrs, to_encode, pki):
    encodedAttrs = encodeAttrs(attrs,to_encode,)
    prover = Prover(pki)
    prover.set_attrs(attrs)
    return prover, encodedAttrs, attrs