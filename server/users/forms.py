from django.contrib.auth.forms import (UserCreationForm as UserForm,
                                       UserChangeForm as ChangeForm)

from .models import User


class UserCreationForm(UserForm):

    class Meta:
        model = User
        fields = ('email',)


class UserChangeForm(ChangeForm):

    class Meta:
        model = User
        fields = ('email',)
