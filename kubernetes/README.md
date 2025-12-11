# Kubernetes Homelab

This folder contains the manifests for my real K3s-based homelab.  
The cluster runs in production on physical hardware and is managed with kustomize, MetalLB, and a mix of Longhorn + NFS-based RWX storage.

## Structure

kubernetes/
media/ # Jellyfin, Sonarr, Radarr, qBittorrent, Prowlarr
home/ # Home Assistant deployment
metallb/ # Load balancer IP pool + L2 advertisement
media/longhorn/ # Static NFS PV + bound RWX PVC for all media apps


## Highlights

### Media Stack (Namespace: media)
A full production-grade media automation setup powered by:

- **Jellyfin** (GPU-accelerated, VAAPI, mapped /dev/dri, node pinned)
- **Sonarr / Radarr** (uses shared RWX media storage)
- **qBittorrent** (initContainer patches qBittorrent.conf automatically)
- **Prowlarr** (indexer manager)

All applications share a **single RWX NFS-backed PVC** mounted at `/media`.

### Storage Design

- `media-storage-nfs` -> static PV (2Ti), NFS v4.2  
- `media-storage` -> PVC bound to the static PV  
- Ensures consistent paths across apps: `/media`

This mirrors my actual hardware layout where the controller exposes a Samba/NFS share.

### Networking

MetalLB provides LoadBalancer services using a clean, deterministic range:

172.20.50.200 - 172.20.50.250


Each app receives a dedicated address (mirroring my Pi-hole DNS hostnames like jelly.box, radarr.box, qbit.box).

### Home Assistant (Namespace: home)

Longhorn-backed PVC, single Deployment + LoadBalancer service.  
Identical to the real setup running in my house.

## Apply

Using kustomize:

kustomize build kubernetes/media | kubectl apply -f -
kustomize build kubernetes/home | kubectl apply -f -


This
