from torch.utils.data import Dataset
import numpy as np
from PIL import Image

class FEMNIST_LEAF(Dataset):
    def __init__(self, images, labels, transform=None):
        self.data = images
        self.targets = labels
        self.transform = transform

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        img, target = self.data[idx], int(self.targets[idx])
            
        if img is isinstance(img, np.ndarray):
            img = Image.fromarray(img.reshape(-1, 28))
        else:
            img = Image.fromarray(np.array(img).reshape(-1, 28))

        if self.transform is not None:
            img = self.transform(img)

        return img, target