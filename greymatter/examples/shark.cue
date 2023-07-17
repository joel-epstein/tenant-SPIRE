package examples

import (
	gsl "greymatter.io/gsl/v1"

	"examples.module/greymatter:globals"
)


Shark: gsl.#Service & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: Shark.#NewContext & globals

	// name must follow the pattern namespace/name
	name:          "shark"
	display_name:  "Examples Shark"
	version:       "v1.0.0"
	description:   "EDIT ME"
	api_endpoint:              "https://\(context.globals.edge_host)/services/\(context.globals.namespace)/\(name)/"
	api_spec_endpoint:         "https://\(context.globals.edge_host)/services/\(context.globals.namespace)/\(name)/"
	
	business_impact:           "low"
	owner: "Examples"
	capability: ""
	health_options: {
		spire: gsl.#SpireUpstream & {
			#context: context.SpireContext
			#subjects: ["greymatter-datastore"]
		}
	}
	// Shark -> ingress to your container
	ingress: {
		(name): {
			gsl.#HTTPListener
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["examples-edge"]
			}
			
			//  NOTE: this must be filled out by a user. Impersonation allows other services to act on the behalf of identities
			//  inside the system. Please uncomment if you wish to enable impersonation. If the servers list if left empty,
			//  all traffic will be blocked.
			// filters: [
			// 	gsl.#ImpersonationFilter & {
			// 			#options: {
			// 				servers: "CN=alec.holmes,OU=Engineering,O=Decipher Technology Studios,L=Alexandria,ST=Virginia,C=US|x500UniqueIdentifier=e68ef81ca228f4dc66dd5ad696386d96,O=SPIRE,C=US"
			// 				caseSensitive: false
			// 			}
			// 	},
			// ]
			routes: {
				"/": {
					
					upstreams: {
						"local": {
							gsl.#Upstream
							
							instances: [
								{
									host: "127.0.0.1"
									port: 9090
								},
							]
						}
					}
				}
			}
		}
	}


	
	// Edge config for the Shark service.
	// These configs are REQUIRED for your service to be accessible
	// outside your cluster/mesh.
	edge: {
		edge_name: "edge"
		routes: "/services/\(context.globals.namespace)/\(name)": {
			prefix_rewrite: "/"
			upstreams: (name): {
				gsl.#Upstream
				namespace: context.globals.namespace
				gsl.#SpireUpstream & {
					#context: {
						globals.globals
						service_name: "edge"
					}
					#subjects: ["examples-shark"]
				}
			}
		}
	}
	
}

exports: "shark": Shark
